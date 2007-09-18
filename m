From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Subject: Re: [2/3] 2.6.23-rc6: known regressions v2
Date: Tue, 18 Sep 2007 09:31:41 -0500
Message-ID: <1190125901.6528.7.camel@norville.austin.ibm.com>
References: <46EB3E94.7080704@googlemail.com> <46EB4371.307@googlemail.com>
	 <20070918142443.GA13304@atrey.karlin.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org,
	jfs-discussion@lists.sourceforge.net,
	Andy Whitcroft <apw@shadowen.org>, sct@redhat.com,
	adilger@clusterfs.com, linux-ext4@vger.kernel.org,
	netdev@vger.kernel.org, Shish <shish@shishnet.org>,
	Karl Meyer <adhocrocker@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Daniel Drake <dsd@gentoo.org>,
	Oliver Neukum <oliver@neukum.org>,
	linux-usb-devel@lists.sourceforge.net,
	Florian Lohoff <flo@rfc822.org>,
	Toralf F?rster <toralf.foerster@gmx.de>
To: Jan Kara <jack@suse.cz>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070918142443.GA13304@atrey.karlin.mff.cuni.cz>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-09-18 at 16:24 +0200, Jan Kara wrote:

> > Subject         : umount triggers a warning in jfs and takes almost a minute
> > References      : http://lkml.org/lkml/2007/9/4/73
> > Last known good : ?
> > Submitter       : Oliver Neukum <oliver@neukum.org>
> > Caused-By       : ?
> > Handled-By      : ?
> > Status          : unknown
>   I thought Shaggy asked Oliver about some details (and he did not
> answer so far) so I'd assume Shaggy is handling this.

I've put it on the back-burner since I haven't heard back from Oliver.
I still haven't found out whether or not it is a regression.  I'm not
too concerned about fixing it right away.  I don't think jfs on flash is
very important.

-- 
David Kleikamp
IBM Linux Technology Center

