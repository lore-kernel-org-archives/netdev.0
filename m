From: Greg KH <gregkh@suse.de>
Subject: Re: [BUG] skge 0000:02:05: read data parity error
Date: Mon, 14 Jan 2008 13:38:02 -0800
Message-ID: <20080114213802.GA7860@suse.de>
References: <6101e8c40801141157j1ce7d3f0if2e4eb2344b6c844@mail.gmail.com> <20080114125200.28cb4c69@deepthought> <20080114210105.GG9847@does.not.exist> <6101e8c40801141331n3cb66c04pc74ff07faf04c8fd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Oliver Pinter (Pint?r Oliv?r)" <oliver.pntr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49884 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751568AbYANVhk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 16:37:40 -0500
Content-Disposition: inline
In-Reply-To: <6101e8c40801141331n3cb66c04pc74ff07faf04c8fd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 14, 2008 at 10:31:03PM +0100, Oliver Pinter (Pint?r Oliv?r) wrote:
> I think, it is a potential security breakpoint, when applications with
> root permission its read, then a machine is freezed, or only i thin
> it's?

I'm sorry, I don't quite understand what you are trying to say here.
