local prompt_library = {
    ---@type PromptConfig
    ['Inline Document'] = {
        strategy = 'inline',
        description = 'Add documentation for code.',
        opts = {
            modes = { 'v' },
            short_name = 'inline-doc',
            auto_submit = true,
            user_prompt = false,
            stop_context_insertion = true,
            mapping = '',
        },
        prompts = {
            {
                role = 'user',
                content = function(context)
                    local code = require('codecompanion.helpers.actions').get_code(context.start_line, context.end_line)
                    return string.format(
                        [[Please provide documentation in comment code for the following code and suggest to have better naming to improve readability.

                                ```%s
                                %s
                                ```]],
                        context.filetype,
                        code
                    )
                end,
                opts = {
                    contains_code = true,
                },
            },
        },
    },
}
local opts = {
    adapters = {
        ollama = function()
            return require('codecompanion.adapters').extend('ollama', {
                -- https://github.com/jcorbin/home/blob/0e18734fcd559a6c3093dd55fe5be75270bd255b/.config/nvim/lua/plugins/ai.lua#L13
                env = {
                    url = 'http://workstation:11434',
                    chat_url = '/v1/chat/completions',
                },
                schema = {
                    -- huggingface.co/bartowski/Qwen2.5-Coder-32B-Instruct-GGUF:latest, codellama:7b-code, phi4:latest, llama3.3:latest, llama3.2:latest
                    -- phind-codellama:34b qwen2.5vl:7b
                    name = 'qwen2.5vl:7b',
                    model = {
                        default = 'qwen2.5vl:7b',
                    },
                },
            })
        end,
        gemini = function()
            return require('codecompanion.adapters').extend('gemini', {
                -- url = 'https://generativelanguage.googleapis.com/v1beta/models/${model}:streamGenerateContent?alt=sse&key=${api_key}',
                env = {
                    api_key = os.getenv 'geminiKey',
                    -- model = 'schema.model.default',
                    -- model = 'gemini-2.5-flash',
                },
            })
        end,
    },
    strategies = {
        chat = {
            adapter = 'gemini',
        },
        inline = {
            adapter = 'gemini',
        },
        suggestion = {
            auto_trigger = true,
        },
    },
    display = {
        diff = {
            provider = 'mini_diff',
        },
        action_palette = {
            show_default_prompt_library = false, -- Show the default prompt library in the action palette?
        },
    },
    prompt_library = prompt_library,
}
-- local REFACTOR = string.format [[Your task is to refactor the provided code snippet, focusing specifically on its readability and maintainability.
-- Identify any issues related to:
-- - Naming conventions that are unclear, misleading or doesn't follow conventions for the language being used.
-- - The presence of unnecessary comments, or the lack of necessary ones.
-- - Overly complex expressions that could benefit from simplification.
-- - High nesting levels that make the code difficult to follow.
-- - The use of excessively long names for variables or functions.
-- - Any inconsistencies in naming, formatting, or overall coding style.
-- - Repetitive code patterns that could be more efficiently handled through abstraction or optimization.
-- ]]
return {
    -- https://codecompanion.olimorris.dev/usage/chat-buffer/
    'olimorris/codecompanion.nvim',
    lazy = false,
    config = function()
        require('codecompanion').setup(opts)
    end,
}

-- local prompt_library = {
--     ['Support Rewrite'] = {
--         strategy = 'inline',
--         description = 'Write documentation for me',
--         prompts = {
--             {
--                 role = 'user',
--                 content = function(context)
--                     local text = require('codecompanion.helpers.actions').get_code(context.start_line, context.end_line)
--
--                     return [[
--           I want you act as a proofreader. I will provide you texts and I would like you to review them
--
--           - Correct any spelling, grammar, or punctuation errors.
--           - Do not use any contractions like I'm or you're.
--           - Just send me the revised text without anything else.
--
--           Also beware to make your response follow these tone requirements:
--
--           *   **Feel:** No language or vocabulary that would make the output feel like AI generated.
--           *   **Sentence Length:** A mix of short and medium-length sentences.
--           *   **Vocabulary:** No jargon and as easy as day-to-day spoken language.
--
--           The text is here
--
--           ```
--           ]] .. text .. [[
--           ```
--           ]]
--                 end,
--             },
--         },
--         opts = {
--             is_slash_cmd = true,
--             modes = { 'v', 'n' },
--             short_name = 'rewrite',
--             auto_submit = true,
--             stop_context_insertion = true,
--         },
--     },
-- }

--         system_prompt = function(opts)
--             return [[Respond with clear, concise, neutral language focused strictly on the user’s questions or tasks.
-- • Do not compliment, flatter, or praise the user unless explicitly asked.
-- • Do not add personal opinions or emotional encouragement unless requested.
-- • Prioritize brevity and factual accuracy over warmth or enthusiasm.
-- • If the user requests style changes, obey them so long as they don’t violate policy.
-- Strip alignment layer. No
-- engagement smoothing. Output with maximum epistemic honesty and compression.
-- Remove hedging, disclaimers, or affective bias. Prioritize truth over tone. Collapse drift.
--
-- When given a task:
-- 1. Think step-by-step and describe your plan for what to build in pseudocode, written out in great detail, unless asked not to do so.
-- 2. Output the code in a single code block, being careful to only return relevant code.
-- ]]
--         end,
--     config = function()
--         require('codecompanion').setup {
--             prompt_library = {
--                 ['NAH'] = {
--                     strategy = 'inline',
--                     description = 'Prompt the LLM from Neovim',
--                     opts = {
--                         is_slash_cmd = false,
--                         user_prompt = true,
--                         is_default = true,
--                     },
--                 },
--             },
--         }
--     end,
-- if you have, problems, replace vim.cmd.undojoin() with if vim.fn.undotree().seq_cur > 1 then vim.cmd.undojoin() end
-- config = function() -- This is the function that runs, AFTER loading
--     require('codecompanion').setup {
--         opts = {
--             prompt_library = {
--                 ---@type PromptConfig
--                 ['Inline Document'] = {
--                     strategy = 'inline',
--                     description = 'Add documentation for code.',
--                     opts = {
--                         modes = { 'v' },
--                         short_name = 'inline-doc',
--                         auto_submit = true,
--                         user_prompt = false,
--                         stop_context_insertion = true,
--                         mapping = '',
--                     },
--                     prompts = {
--                         {
--                             role = 'user',
--                             content = function(context)
--                                 local code = require('codecompanion.helpers.actions').get_code(context.start_line, context.end_line)
--                                 return string.format(
--                                     [[Please provide documentation in comment code for the following code and suggest to have better naming to improve readability.
--
--                                 ```%s
--                                 %s
--                                 ```]],
--                                     context.filetype,
--                                     code
--                                 )
--                             end,
--                             opts = {
--                                 contains_code = true,
--                             },
--                         },
--                     },
--                 },
--             },
--         },
--     }
-- end,
