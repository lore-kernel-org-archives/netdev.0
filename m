From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Linux XIA - merge proposal
Date: Tue, 3 Mar 2015 21:49:24 -0800
Message-ID: <20150304054924.GA27610@kroah.com>
References: <54F5EF6E.9090303@digirati.com.br>
 <54F64B75.3010109@iogearbox.net>
 <54F6527E.6080406@digirati.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Michel Machado <michel@digirati.com.br>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54F6527E.6080406@digirati.com.br>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 03, 2015 at 07:31:58PM -0500, Michel Machado wrote:
> Hi Daniel,
> 
> >>We're fine with clearly marking Linux XIA as being under staging
> >>as well as helping to define this review process for network stacks.
> >
> >With regard to staging, the code there is usually horrible and I'm
> >not sure anyone really looks there, that would mitigate the review
> >problem to the time when you try to get it out from there, so I'm
> >not sure it brings anything. ;)
> 
>    I suggested staging as a way to incrementally review the code.

Yet you failed to at least ask the maintainer of the staging portion of
the kernel, if this is a valid use of staging, and his resources...

Not nice :(

greg k-h
