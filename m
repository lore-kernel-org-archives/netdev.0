From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC][PATCHES] iov_iter.c rewrite
Date: Mon, 8 Dec 2014 20:56:35 +0200
Message-ID: <20141208185635.GA25867@node.dhcp.inet.fi>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
 <20141208164650.GB29028@node.dhcp.inet.fi>
 <20141208175805.GB22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141208175805.GB22149@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 08, 2014 at 05:58:05PM +0000, Al Viro wrote:
> On Mon, Dec 08, 2014 at 06:46:50PM +0200, Kirill A. Shutemov wrote:
> 
> > I guess this crash is related to the patchset.
> 
> Might be.  Do you have a reproducer for it?

trinity triggers it for me in few minutes. I will try find out more once
get some time.

-- 
 Kirill A. Shutemov
