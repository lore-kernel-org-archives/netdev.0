From: "Dotan Barak" <dotanba@gmail.com>
Subject: Re: How can i know if I/OAT is supported?
Date: Mon, 16 Jun 2008 15:14:45 +0300
Message-ID: <2f3bf9a60806160514y4b6259c9reb21c1df427dcf19@mail.gmail.com>
References: <2f3bf9a60806160351l3611d9f7jef90d51e257b059d@mail.gmail.com>
	 <Pine.LNX.4.64.0806161214540.2344@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Krzysztof Oledzki" <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:2180 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753180AbYFPMPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 08:15:13 -0400
Received: by wa-out-1112.google.com with SMTP id j37so4320495waf.23
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2008 05:15:13 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0806161214540.2344@bizon.gios.gov.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the fast response.

>> I'm trying to use the I/OAT technology but i don't know if the the
>> sent data used this technology.
>> Are there are any counters which indicates how many data was sent using
>> I/OAT?
>
> for f in /sys/class/dma/*; do echo "$f: bytes=`cat $f/bytes_transferred`
> count=`cat $f/memcpy_count`" ; done

I have the folder /sys/class/dma/, but this folder is empty.
What does it mean?

thanks
Dotan
