From: Greg KH <gregkh@suse.de>
Subject: Re: [GIT] Networking
Date: Tue, 25 Oct 2011 15:13:15 +0200
Message-ID: <20111025131315.GA1899@suse.de>
References: <20111025.063206.2273357152859701628.davem@davemloft.net>
 <CA+55aFw1GVvszqoC_f0RAvG5t1xj0CSYLhLU=y0gQ+_54Gsomw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Mikulas Patocka <mpatocka@redhat.com>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFw1GVvszqoC_f0RAvG5t1xj0CSYLhLU=y0gQ+_54Gsomw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 25, 2011 at 01:46:11PM +0200, Linus Torvalds wrote:
> Anyway, after that rant about really bad practices, let me say that I
> did fix up the conflict and I think it's right. But I won't guarantee
> it, so please check the changes to fs/sysfs/dir.c.

I think it looks ok, I've booted the merge result, and am typing and
sending this from the new kernel, and it hasn't crashed yet :)

greg k-h
