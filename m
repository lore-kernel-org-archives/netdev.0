From: Matthew Fernandez <matthew.fernandez@gmail.com>
Subject: Re: [PATCH] bpf: fix trivial comment typo
Date: Thu, 5 Nov 2015 11:05:01 +1100
Message-ID: <563A9D2D.90802@gmail.com>
References: <5636B557.1030804@gmail.com>
 <20151102.163138.2054202316045092354.davem@davemloft.net>
 <5637DA1F.6060501@gmail.com> <563882FB.1010008@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, trivial@kernel.org, ast@kernel.org,
	linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <563882FB.1010008@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/11/15 20:48, Daniel Borkmann wrote:
> On 11/02/2015 10:48 PM, Matthew Fernandez wrote:
>> On 03/11/15 08:31, David Miller wrote:
>>> From: Matthew Fernandez <matthew.fernandez@gmail.com>
>>> Date: Mon, 2 Nov 2015 11:59:03 +1100
>>>
>>>> bpf: fix trivial comment typo
>>>>
>>>> Signed-off-by: Matthew Fernandez <matthew.fernandez@gmail.com>
>>>
>>> This doesn't apply to any tree.
>>
>> I'm sorry, I think I must be missing something. This seems to apply cleanly to the current tip of
>> mainline (e86328c489d7) to me. Was this not in the expected format? It wasn't my intention to
>> waste your time, so I apologise for any newbie errors.
>
> You might want to check Documentation/networking/netdev-FAQ.txt ;),
> and rebase your spelling fix f.e. to the latest net-next tree.

Ah right, sorry about that. Thanks for the info, Daniel. From netdev-FAQ it sounds like this patch 
would be more appropriate for the net tree, but as the target file is identical in both right now 
I'll leave it to someone else's discretion to decide which is more suitable. Will rebase and resubmit.
