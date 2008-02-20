From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 2.6.25 2/4]S2io: Multiqueue network device support - FIFO selection based on L4 ports
Date: Wed, 20 Feb 2008 17:57:44 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77030E30E5@nekter>
References: <Pine.GSO.4.10.10802201644130.11320-100000@guinness> <47BCA6C5.1070805@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"support" <support@neterion.com>
To: "Patrick McHardy" <kaber@trash.net>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:12085 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755252AbYBTXAX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 18:00:23 -0500
Content-class: urn:content-classes:message
In-Reply-To: <47BCA6C5.1070805@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Sreenivasa Honnur wrote:
> > - Resubmit #2
> > - Transmit fifo selection based on TCP/UDP ports.
> > - Added tx_steering_type loadable parameter for transmit fifo
selection.
> >   0x0 NO_STEERING: Default FIFO is selected.
> >   0x1 TX_PRIORITY_STEERING: FIFO is selected based on skb->priority.
> >   0x2 TX_DEFAULT_STEERING: FIFO is selected based on L4 Ports.
> >
> 
> Why duplicate the generic multiqueue classification?
[Ram] Could you be more specific?

Ram
> 

