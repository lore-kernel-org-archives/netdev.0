From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2.6.10-rc1 1/15] wireless/orinoco: Use msleep() instead of hardcoded schedule_timeout()s
Date: Tue, 26 Oct 2004 20:42:19 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026194219.GA17343@infradead.org>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com> <1098815604.3663.35.camel@dcbw.boston.redhat.com> <20041026184749.GA16621@infradead.org> <1098819336.9874.11.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, netdev@oss.sgi.com,
        jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1098819336.9874.11.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 26, 2004 at 03:35:36PM -0400, Dan Williams wrote:
> New description:
> 
> o Use msleep() instead of hardcoded schedule_timeout()s
> o Normalize sleep calls to use msleep() everywhere

care to explain what's the point of the latter?
