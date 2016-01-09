From: Pascal Hambourg <pascal@plouf.fr.eu.org>
Subject: Re: Configure ICMP error source address
Date: Sat, 09 Jan 2016 23:55:09 +0100
Message-ID: <56918FCD.5060308@plouf.fr.eu.org>
References: <568F8207.9040305@heinlein-support.de> <20160108152448.5251154.50977.21786@gmail.com> <568FDFBF.3010300@stressinduktion.org> <20160109035708.5251154.82433.21820@gmail.com> <5690D98B.7070003@stressinduktion.org> <56913852.4030608@heinlein-support.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netfilter@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <56913852.4030608@heinlein-support.de>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Sander a =E9crit :
>=20
> Is it a good idea to set a specific global IPv4 address as source
> address for outgoing ICMP error messages?

Why only for ICMP error messages and not all outgoing packets sent to a
global destination address ?
