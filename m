From: jamal <hadi@cyberus.ca>
Subject: Re: and the packet, sorry
Date: Tue, 30 Jul 2002 08:16:04 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0207300808280.15727-100000@shell.cyberus.ca>
References: <20020730104845.GB22307@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20020730104845.GB22307@outpost.ds9a.nl>
List-Id: netdev.vger.kernel.org




Bad NIC? happens on other kernels?
tcpdump lying? (not that hasnt been known to do that before) verify
by looking at output of netstat -s and look at udp "packet receive errors"
see if they are going up.

cheers,
jamal
