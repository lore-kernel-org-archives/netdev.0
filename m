From: Ben Greear <greearb@candelatech.com>
Subject: Re: Broadcom 43xx first results
Date: Tue, 06 Dec 2005 08:43:39 -0800
Message-ID: <4395BFBB.8060304@candelatech.com>
References: <E1Eiyw4-0003Ab-FW@www1.emo.freenet-rz.de> <20051205190038.04b7b7c1@griffin.suse.cz> <4394892D.2090100@gentoo.org> <20051205195543.5a2e2a8d@griffin.suse.cz> <20051205191008.GA28433@infradead.org> <20051205203121.48241a08@griffin.suse.cz> <20051205194146.GA29317@infradead.org> <20051205211107.61941ab9@griffin.suse.cz> <20051206150909.GB1999@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, Christoph Hellwig <hch@infradead.org>,
	Joseph Jezak <josejx@gentoo.org>, mbuesch@freenet.de,
	linux-kernel@vger.kernel.org, NetDev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932315AbVLFQoY@vger.kernel.org>
To: Pavel Machek <pavel@suse.cz>
In-Reply-To: <20051206150909.GB1999@elf.ucw.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Machek wrote:
> Hi!
> 
> 
>>>That's because you still don't get how we do development.  The last thing
>>>we want is full-scale rewrites.  Submit patches to fix things based on
>>>whatever you want but do it incremental.
>>
>>We have got almost finished and working stack. Everything we need to do
>>is:
>>1. identify issues;
>>2. fix the issues; some of them will need broader discussion;
>>3. split it into several (potentially a lot of) reviewable patches;
>>4. clean up the drivers.
>>
>>I'm in phase 2 now (no interesting results yet). I don't think it is
> 
> 
> No, it does not work like that. You don't get nice, reviewable,
> mergeable patches by developing code independently for 3 years or so
> then attempting merge.
> 
> If devicescape code is better than mainline, merge it _now_. If it is
> not, drop it and start from mainline code.

Merge now even if it breaks the current tree?  I for one would certainly
rather he finish his work on it and get it more polished.  Reviewing and
testing something that actually works would be a lot more fun...


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
