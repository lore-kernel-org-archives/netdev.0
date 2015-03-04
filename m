From: Michel Machado <michel@digirati.com.br>
Subject: Re: Linux XIA - merge proposal
Date: Wed, 04 Mar 2015 08:01:04 -0500
Message-ID: <54F70210.5070900@digirati.com.br>
References: <54F5EF6E.9090303@digirati.com.br> <54F64B75.3010109@iogearbox.net> <54F6527E.6080406@digirati.com.br> <20150304054924.GA27610@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150304054924.GA27610@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/04/2015 12:49 AM, Greg KH wrote:
> On Tue, Mar 03, 2015 at 07:31:58PM -0500, Michel Machado wrote:
>> Hi Daniel,
>>
>>>> We're fine with clearly marking Linux XIA as being under staging
>>>> as well as helping to define this review process for network stacks.
>>>
>>> With regard to staging, the code there is usually horrible and I'm
>>> not sure anyone really looks there, that would mitigate the review
>>> problem to the time when you try to get it out from there, so I'm
>>> not sure it brings anything. ;)
>>
>>     I suggested staging as a way to incrementally review the code.
>
> Yet you failed to at least ask the maintainer of the staging portion of
> the kernel, if this is a valid use of staging, and his resources...
>
> Not nice :(
>
> greg k-h

Hi Greg,

    I am sorry for having not asked you. Given that the staging process 
doesn't include network stacks, I'd thought that the correct way to go 
would be to bring the discussion to netdev first. Please understand that 
I'm not gaming, I'm just following my best understanding of the 
documentation of how to submit code. I'm really in uncharted waters here 
since all my accepted patches are tiny.

    In addition, I intend to work on the feedback I get. I'm not 
planning to have the code upstream and run away.

[ ]'s
Michel Machado
