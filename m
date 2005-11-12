From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC: 2.6 patch] remove ISA legacy functions
Date: Sat, 12 Nov 2005 00:27:56 -0500
Message-ID: <43757D5C.8030308@pobox.com>
References: <20051107200336.GH3847@stusta.de> <20051110042857.38b4635b.akpm@osdl.org> <20051111021258.GK5376@stusta.de> <20051110182443.514622ed.akpm@osdl.org> <20051111201849.GP5376@stusta.de> <20051111202005.GQ5376@stusta.de> <20051111203601.GR5376@stusta.de> <20051112045216.GY5376@stusta.de> <437578CD.1080501@pobox.com> <20051112051102.GF1658@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, Andrew Morton <akpm@osdl.org>,
	linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org, jonathan@buzzard.org.uk,
	tlinux-users@tce.toshiba-dme.co.jp, Jaroslav Kysela <perex@suse.cz>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932120AbVKLF2J@vger.kernel.org>
To: Matthew Wilcox <matthew@wil.cx>
In-Reply-To: <20051112051102.GF1658@parisc-linux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> On Sat, Nov 12, 2005 at 12:08:29AM -0500, Jeff Garzik wrote:
> 
>>it's not valid to mark working drivers broken, IMO.
>>
>>Mark them x86-only, perhaps.
> 
> 
> hp100 works fine on parisc.

Certainly.  The point was, don't mark them broken, limit them to the 
arches where they work.

	Jeff
