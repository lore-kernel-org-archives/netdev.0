From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6.0-test4][NET] 3c509.c: remove device.name field
Date: Sun, 24 Aug 2003 05:03:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030824050308.0a3feee0.davem@redhat.com>
References: <1061644409.1141.18.camel@lima.royalchallenge.com>
	<20030824034735.534b8c68.davem@redhat.com>
	<1061727940.1288.4.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Vinay K Nallamothu <vinay-rc@naturesoft.net>
In-Reply-To: <1061727940.1288.4.camel@lima.royalchallenge.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 24 Aug 2003 17:55:40 +0530
Vinay K Nallamothu <vinay-rc@naturesoft.net> wrote:

> On Sun, 2003-08-24 at 16:17, David S. Miller wrote:
> > On 23 Aug 2003 18:43:29 +0530
> > Vinay K Nallamothu <vinay-rc@naturesoft.net> wrote:
> > 
> > > This patch removes the device name field which is no longer present.
> > 
> > This doesn't look like the right fix.  You can't just
> > delete these lines, you should rather replace them with
> > accesses to whatever the MCA device struct name field is.
> > 
> > 
> Pls find the updated patch (hopefully right this time) below:

Applied, thanks.
