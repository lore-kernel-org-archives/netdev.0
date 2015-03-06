From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 0/7] Freescale DPAA FMan FLIB(s)
Date: Fri, 06 Mar 2015 10:09:45 -0500
Message-ID: <54F9C339.2050409@mojatatu.com>
References: <1425534351-1065-1-git-send-email-Emilian.Medve@Freescale.com> <54F84CF1.80702@mojatatu.com> <54F85ECB.3070200@Freescale.com> <54F869CE.1080701@mojatatu.com> <54F87096.2070709@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Igal Liberman <Igal.Liberman@Freescale.com>
To: Emil Medve <Emilian.Medve@Freescale.com>,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54F87096.2070709@Freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Emil,

On 03/05/15 10:04, Emil Medve wrote:
> Hello Jamal,
>
>
> On 03/05/2015 08:35 AM, Jamal Hadi Salim wrote:
>> Hi Emil,
>>
>
> No. All the kernel drivers/code we want to upstream is meant to stand on
> its own and be used the "normal" Linux/Unix way
>

Ok, thanks - that was my only concern.
Note there is a lot of offload efforts going on in Linux right now.
Take a look at the proceedings from netdev01. You should take advantage
of that to shape the direction of your patches.
I have suffered at the hands of the sdk for this processor in the past;
it is just a bad idea to keep these SDKs around when Linux can express
the features sufficiently.
Note: The main thing i'd be interested in is when you get to offloading
the classifier/scheduler etc. I know you are focussing on just the 
ethernet level at the moment,

cheers,
jamal
