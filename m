From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [RFC: 2.6 patch] remove ISA legacy functions
Date: Wed, 16 Nov 2005 03:56:50 +0000
Message-ID: <20051116035650.GA27946@ftp.linux.org.uk>
References: <20051110182443.514622ed.akpm@osdl.org> <20051111201849.GP5376@stusta.de> <20051111202005.GQ5376@stusta.de> <20051111203601.GR5376@stusta.de> <20051112045216.GY5376@stusta.de> <437578CD.1080501@pobox.com> <20051112051102.GF1658@parisc-linux.org> <43757D5C.8030308@pobox.com> <20051112052918.GG1658@parisc-linux.org> <20051112134820.GG7992@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Adrian Bunk <bunk@stusta.de>,
	Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	jonathan@buzzard.org.uk, tlinux-users@tce.toshiba-dme.co.jp,
	Jaroslav Kysela <perex@suse.cz>
Return-path: <linux-scsi-owner@vger.kernel.org>
To: Matthew Wilcox <matthew@wil.cx>
Content-Disposition: inline
In-Reply-To: <20051112134820.GG7992@ftp.linux.org.uk>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 12, 2005 at 01:48:20PM +0000, Al Viro wrote:
> On Fri, Nov 11, 2005 at 10:29:18PM -0700, Matthew Wilcox wrote:
> > I think they work fine everywhere.  Adrian wants to remove the API they
> > use.
> > 
> > I think this is a bad idea.  The drivers should be converted.
> 
> They are - I'll send patches later today...

NB: never say these words on a Friday night or you'll get a visit from
Murphy.

Apologies for delay, patches sent.
