From: "John Que" <qwejohn@gmail.com>
Subject: checksum when switching between source and dest addresses in IP header - newbie
Date: Tue, 26 Sep 2006 13:25:55 +0300
Message-ID: <ada605fb0609260325m2486428dhd94625ad0fa5e547@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.224]:32809 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1751100AbWIZKZz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 06:25:55 -0400
Received: by wx-out-0506.google.com with SMTP id s14so2146738wxc
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 03:25:55 -0700 (PDT)
To: netdev <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

  I am not familiar with the details of checksum algorithm of ip headers;
My question is this:

When switching between source and dest addresses in an IP header of an
IP packet - should the checksum of the ip header be changed ?
Or is the checksum algorithm indifferent to which is the IP src address and
IP dest address in the ip header ?

Regards,
John
