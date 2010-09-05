From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/2] [RFC] posix clock tuning
Date: Sun, 5 Sep 2010 07:56:21 +0200
Message-ID: <20100905055621.GA2699@riccoc20.at.omicron.at>
References: <cover.1283504065.git.richard.cochran@omicron.at>
 <alpine.DEB.2.00.1009041221240.888@router.home>
 <4C828652.4060804@gmail.com>
 <alpine.DEB.2.00.1009042036540.9425@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Riesch <christian.riesch-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1009042036540.9425-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 04, 2010 at 08:37:22PM -0500, Christoph Lameter wrote:
> On Sat, 4 Sep 2010, Christian Riesch wrote:
> 
> > Richard's idea is to support clock hardware for IEEE 1588 (PTP, Precision Time
> > Protocol). Have a look at the earlier discussions:
> 
> Ok great. A summary of that belongs into the intro of the patchset.

I left off all mention of PTP, since Alan Cox said that all this talk
of PTP is not helpful. I think that the idea is introduce a method to
tune a clock referenced by its clockid_t. In other words, a patch for
tuning posix clocks, just as the subject lines indicate.

Richard
