From: Eric Mudama <edmudama@gmail.com>
Subject: Re: The ultimate TOE design
Date: Wed, 22 Sep 2004 17:25:38 -0600
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <311601c904092216257bfd5752@mail.gmail.com>
References: <4148991B.9050200@pobox.com>
	 <OF8783A4F6.D566336C-ON88256F10.006E51CE-88256F10.006EDA93@us.ibm.com>
	 <311601c90409162346184649eb@mail.gmail.com>
	 <200409172027.i8HKRVwY005444@turing-police.cc.vt.edu>
Reply-To: Eric Mudama <edmudama@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>, Netdev <netdev@oss.sgi.com>,
	leonid.grossman@s2io.com,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268119AbUIVXZl@vger.kernel.org>
To: "valdis.kletnieks@vt.edu" <valdis.kletnieks@vt.edu>
In-Reply-To: <200409172027.i8HKRVwY005444@turing-police.cc.vt.edu>
List-Id: netdev.vger.kernel.org

On Fri, 17 Sep 2004 16:27:31 -0400, valdis.kletnieks@vt.edu
<valdis.kletnieks@vt.edu> wrote:
> No, he means "offload the processing of the filesystem to the disk itself".

I know what was meant.

I'm not saying the filesystem on the drive is very advanced, but it's
still a filesystem.  Our "Record ID" is the LBA identifier, and all
records are 1 block in size.  We can handle defects, reallocations,
and other issues, with some success.
