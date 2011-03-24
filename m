From: Jan Altenberg <jan@linutronix.de>
Subject: RE: c_can: TX handling
Date: Thu, 24 Mar 2011 11:56:41 +0100
Message-ID: <1300964201.3295.16.camel@localhost>
References: <16a340801622a96218c76dbbabc7a23f.squirrel@www.linutronix.de>
	 <D5ECB3C7A6F99444980976A8C6D896384DF0D6F684@EAPEX1MAIL1.st.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "wg@grandegger.com" <wg@grandegger.com>,
	"kurt.van.dijck@eia.be" <kurt.van.dijck@eia.be>,
	"b.spranger@linutronix.de" <b.spranger@linutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	jan@linutronix.de
To: Bhupesh SHARMA <bhupesh.sharma@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:39819 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754961Ab1CXKCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 06:02:35 -0400
In-Reply-To: <D5ECB3C7A6F99444980976A8C6D896384DF0D6F684@EAPEX1MAIL1.st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> Thanks for your work on c_can.
> This week has been very busy for me, so please excuse me for the late reply.

No problem.

> Just to better understand this can you send me your *candump* output
> when you see that the message object put earlier in the message RAM
> being pending on the line.
> 
> Your point seems valid but I want to make sure that this is not done by the 
> C_CAN core implicitly..  

I'll try to prepare a (stripped down) test-case, but since I'm quite
busy at the moment, that might take a couple of days.
I'm quite sure, I've seen such a situation, but first of all, I'd like
to sort out, if that was related to the "DA mode".

Cheers,
	Jan

