From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2.6.10-rc1 1/15] wireless/orinoco: Use msleep() instead of hardcoded schedule_timeout()s
Date: Tue, 26 Oct 2004 19:47:49 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026184749.GA16621@infradead.org>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com> <1098815604.3663.35.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1098815604.3663.35.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 26, 2004 at 02:33:24PM -0400, Dan Williams wrote:
> Update in-kernel orinoco wireless drivers to upstream CVS.
> None of this is original code by Dan Williams, simply a
> broken down patch set split-out from upstream orinoco CVS.
> 
> o Use msleep() instead of hardcoded schedule_timeout()s
>   (Nishanth Aravamudan via kernel-janitors list).

the patch doesn't match the description
