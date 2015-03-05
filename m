From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 0/7] Freescale DPAA FMan FLIB(s)
Date: Thu, 05 Mar 2015 09:35:58 -0500
Message-ID: <54F869CE.1080701@mojatatu.com>
References: <1425534351-1065-1-git-send-email-Emilian.Medve@Freescale.com> <54F84CF1.80702@mojatatu.com> <54F85ECB.3070200@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Igal Liberman <Igal.Liberman@Freescale.com>
To: Emil Medve <Emilian.Medve@Freescale.com>,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54F85ECB.3070200@Freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Emil,

On 03/05/15 08:48, Emil Medve wrote:

> The intent is to upstream the entire suite of the DPAA drivers. All the
> drivers are still WIP, but B/QMan have been already presented to the
> upstream community and this is the first attempt to publish (some low
> level code of) the FMan driver. As we go through our internal checklist
> and in the same time address community feedback we'll soon get the
> drivers to be acceptable for the upstream trees
>
> The first version of the actual Ethernet driver will follow imminently
>
> SDK enablement is a side-effect
>

Meaning? Let me ask the question differently:
Do i need your sdk to use the features exposed or can i use something
like tc to set up the deficit rr or wred or the exposed classifiers
and associated actions?
Would your sdk (via user space direct programming) benefit because you
have pushed these pieces into the kernel?

>> How are you planning to
>> add support for your classifiers, queue schedulers etc?
>
> Yes
>

Yes as in these will be available via linux kernel or via your sdk?

>> Is that a patch
>> on top of this or it is something that sits on user space?
>
> Both. Full DPAA/Ethernet enablement will be present in the kernel. We
> also have support for user-space based approach. I'm unsure where/when
> we might publish that. Of course the SDK is always a place you can turn
> to for all the code we have (in whatever state it might be)
>

the sdk is open source?

cheers,
jamal
