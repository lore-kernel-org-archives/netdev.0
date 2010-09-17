From: Nicola Padovano <nicola.padovano@gmail.com>
Subject: Re: problem with flowi structure
Date: Fri, 17 Sep 2010 20:01:59 +0200
Message-ID: <AANLkTinx_18cVq52tmC0-g0qLYXJ5c_u9aad_rz_p2ND@mail.gmail.com>
References: <AANLkTi=bGsvMqnTSanA73FhDH_DashmXTcA1sddtj0P6@mail.gmail.com>
 <1284650768.3352.37.camel@edumazet-laptop> <AANLkTimo1AeBS3rpQj0KtZL15Ct-DGTQMBUsL8hrVNOL@mail.gmail.com>
 <1284652453.3352.38.camel@edumazet-laptop> <AANLkTi=Y7beG4vPDx5eNg-gTN1CVg_G=1+dWwi2Xd2-R@mail.gmail.com>
 <AANLkTim7TeMCG9RQyrrk8WS4+S_y1q06+8FG2-X=1cB-@mail.gmail.com>
 <AANLkTimpnqNSE21u=2qjb5VGJrn_3_--Bqp4veCNXMPE@mail.gmail.com>
 <1284714533.3391.53.camel@edumazet-laptop> <AANLkTi=r__RA=5UfNnhsKizDF6OFVYXcSe9KOPx1zW0u@mail.gmail.com>
 <1284741295.3391.100.camel@edumazet-laptop> <AANLkTi=t2=jqu3XCC-3LK7x1_icke168Bqt-kmds6eOt@mail.gmail.com>
 <1284745887.2235.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: AIJAZ BAIG <aijazbaig1@gmail.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1284745887.2235.7.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> if you say now :
>
> Send a packet to google, please, I dont care of what source address you
> chose, but I am interested to receive an answer, of course. (application
> does not use bind() system call, only a send())

why an application that wants to send a packet to google would send it
with a different source ip of the host in which it resides?
ie. an application is on a machine which ip is: 192.168.0.2 and the
machine has only one ip address...

-- 
Nicola Padovano
e-mail: nicola.padovano@gmail.com
web: http://npadovano.altervista.org
