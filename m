From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6.0-test6][X25] timer cleanup
Date: Thu, 2 Oct 2003 01:36:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031002013620.6d8b6f10.davem@redhat.com>
References: <1065018387.7194.336.camel@lima.royalchallenge.com>
	<20031001155623.06b89258.akpm@osdl.org>
	<1065078208.4340.3.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Vinay K Nallamothu <vinay.nallamothu@gsecone.com>
In-Reply-To: <1065078208.4340.3.camel@lima.royalchallenge.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 02 Oct 2003 12:33:28 +0530
Vinay K Nallamothu <vinay.nallamothu@gsecone.com> wrote:

> On Thu, 2003-10-02 at 04:26, Andrew Morton wrote:
> > Vinay K Nallamothu <vinay.nallamothu@gsecone.com> wrote:
> > >
> > > Replace del_timer, mod_timer sequences with mod_timer.
> > 
> > was this tested?
> No. But compiles fine.

Please find a way to at least minimally test the protocols
you are changing then, or find someone else who can.

Thanks.
