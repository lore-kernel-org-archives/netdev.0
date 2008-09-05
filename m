From: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
Subject: Channel bonding with e1000
Date: Fri, 05 Sep 2008 10:36:26 +0200
Message-ID: <48C0EF8A.9070103@aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from welcomes-you.com ([85.214.50.128]:47768 "EHLO
	smtp.welcomes-you.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105AbYIEJIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 05:08:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a brief problem and would ask for a little assistance:

On a few data servers we intend to do channel bonding. The boxes have
two NICs on the motherboard and two extra ones on an expansion card:

04:00.0 Ethernet controller: Intel Corporation 631xESB/632xESB DPT LAN
Controller Copper (rev 01)
04:00.1 Ethernet controller: Intel Corporation 631xESB/632xESB DPT LAN
Controller Copper (rev 01)
05:02.0 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet
Controller (rev 03)
05:02.1 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet
Controller (rev 03)

My simple question would be: Does it matter which two ports I can use to
channel together when using in a set-up with MTU=9000?

Thanks for a brief answer

Carsten

-- 
Dr. Carsten Aulbert - Max Planck Institute for Gravitational Physics
Callinstrasse 38, 30167 Hannover, Germany
Phone/Fax: +49 511 762-17185 / -17193
http://www.top500.org/system/9234 | http://www.top500.org/connfam/6/list/31
