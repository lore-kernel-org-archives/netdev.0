From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: icmp echo reply and DF
Date: Fri, 01 Sep 2006 16:28:46 +0200
Message-ID: <BAY103-F80FA7B64C2360B1CFF28BB23C0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s33.bay0.hotmail.com ([65.54.246.169]:10372 "EHLO
	bay0-omc2-s33.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S932092AbWIAO2t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 10:28:49 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I kindly would like to know why linux reply to ICMP
echo request packets with the DF bit set always to 0.

I have googled the internet but I have only found
this pretty old message:
http://www.ussg.iu.edu/hypermail/linux/kernel/9804.2/0334.html

I also have found these messages that document this
behaviour:
http://archive.cert.uni-stuttgart.de/archive/bugtraq/2000/08/msg00316.html
http://archive.cert.uni-stuttgart.de/archive/bugtraq/2000/09/msg00261.html
http://archive.cert.uni-stuttgart.de/archive/bugtraq/2000/10/msg00132.html

TIA


