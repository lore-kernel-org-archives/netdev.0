From: jamal <hadi@cyberus.ca>
Subject: Re: Question.. Traffic Shaping in Linux
Date: Mon, 18 Nov 2002 21:43:27 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0211182143080.15104-100000@shell.cyberus.ca>
References: <000001c28edf$d2634ed0$0105a8c0@tedlee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Taekeun Lee <tedlee@ece.skku.ac.kr>
In-Reply-To: <000001c28edf$d2634ed0$0105a8c0@tedlee>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


If i understood you correctly, you already have the router working with
RSVP Daemon, RSVP control packets configuring CBQ mechanism..
Is this correct? So why cant you use other qdiscs using the same
mechanism? What interface are you using right now to setup things?
I take ut you are using the RSVP* classifiers as well?

cheers,
jamal


On Mon, 18 Nov 2002, Taekeun Lee wrote:

> Hello, My name is Taekeun Lee..
>
> I'm a graduate student in Sungkyunkwan Univ. in Korea..
>
> This e-mail address(netdev@oss.sgi.com) is introduced by Alan Cox..
>
> My Question is Traffic shaping in linux..
>
> Existed traffic shaper in Linux kernel module is possible low bandwidth
> limitation.. ( < 1Mbps )
>
> And, High bandwidth limitation can use CBQ kernel facilities..
>
> But, My router is working with RSVP Daemon, RSVP Daemon controls packets
> by CBQ mechanism..
>
> So, I can't use CBQ facility for traffic shaping..
>
>
>
> I want to traffic shaping in Linux without CBQ mechanism..
>
>
>
> Can U suggest a solution to this problem?
>
>
>
> I'm sorry, my poor english..
>
>
>
> [[HTML alternate version deleted]]
>
>
