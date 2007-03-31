From: "Jeff Chua" <jeff.chua.linux@gmail.com>
Subject: Re: [3/4] 2.6.21-rc5: known regressions (v2)
Date: Sat, 31 Mar 2007 10:52:59 +0800
Message-ID: <b6a2187b0703301952s6042fbfdu2e15e0f868a958f4@mail.gmail.com>
References: <Pine.LNX.4.64.0703251559560.6730@woody.linux-foundation.org>
	 <20070330213220.GO14134@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linus Torvalds" <torvalds@linux-foundation.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"Dave Jones" <davej@redhat.com>,
	"Jeremy Fitzhardinge" <jeremy@goop.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, pavel@suse.cz,
	linux-pm@lists.osdl.org, gregkh@suse.de,
	linux-pci@atrey.karlin.mff.cuni.cz,
	"Tobias Doerffel" <tobias.doerffel@gmail.com>,
	"Len Brown" <len.brown@intel.com>, linux-acpi@vger.kernel.org,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"Soeren Sonnenburg" <kernel@nn7.de>, jgarzik@pobox.com,
	linux-ide@vger.kernel.org, "Marcus Better" <marcus@better.se>,
	adaplas@gmail.com, "Jens Axboe" <jens.axboe@oracle.com>,
	"Mike Harris" <atarimike@wavecable.com>,
	"Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
To: "Adrian Bunk" <bunk@stusta.de>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20070330213220.GO14134@stusta.de>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/31/07, Adrian Bunk <bunk@stusta.de> wrote:

> Subject    : ThinkPad doesn't resume from suspend to RAM
> References : http://lkml.org/lkml/2007/2/27/80
>              http://lkml.org/lkml/2007/2/28/348
> Submitter  : Jens Axboe <jens.axboe@oracle.com>
>              Jeff Chua <jeff.chua.linux@gmail.com>
> Status     : unknown

Fixed with CONFIG_NO_HZ unset and patch from Maxim
(http://lkml.org/lkml/2007/3/29/108).

Thanks,
Jeff,
