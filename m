From: Eric Lemoine <eric.lemoine@gmail.com>
Subject: Re: [PATCH 2.6] Add NAPI support to sungem.c
Date: Wed, 15 Sep 2004 07:50:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5cac192f04091422506d13c530@mail.gmail.com>
References: <20040914153537.GE8434@sunbeam.de.gnumonks.org>
	 <20040914124315.716e9c68.davem@davemloft.net>
	 <20040914200238.GM8434@sunbeam.de.gnumonks.org>
Reply-To: Eric Lemoine <eric.lemoine@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        linuxppc-dev@lists.linuxppc.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040914200238.GM8434@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 14 Sep 2004 22:02:38 +0200, Harald Welte <laforge@gnumonks.org> wrote:
> On Tue, Sep 14, 2004 at 12:43:15PM -0700, David S. Miller wrote:
> >
> > Harald.... check current BK it has NAPI support added
> > to the sungem.c driver already, it was written by Eric Lemoine
> > with some fixes by myself and benh :-)
> 
> Gnah, I hate duplicated efforts.  Well, I learned a bit about NIC
> drivers, though :(

Your patch has the netpoll bits while current BK does not.

> Before I start NAPI-enabling natsemi.c (and again duplicate work):  Do
> you know of anybody working on this yet?

I'm not ;-)

PS: If you happened to experiment with the NAPIfied SunGEM driver on
your setup, could you please share the data. Thx.

-- 
Eric
