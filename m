From: "Jari Sundell" <sundell.software@gmail.com>
Subject: Re: [take12 0/3] kevent: Generic event handling mechanism.
Date: Tue, 22 Aug 2006 19:09:45 +0200
Message-ID: <b3f268590608221009q46f66a67w343bd75ab24d9f22@mail.gmail.com>
References: <11561555871530@2ka.mipt.ru> <1156230051.8055.27.camel@entropy>
	 <20060822072448.GA5126@2ka.mipt.ru> <1156234672.8055.51.camel@entropy>
	 <b3f268590608220957g43a16d6bmde8a542f8ad8710b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.199]:9999 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S932192AbWHVRJq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 13:09:46 -0400
Received: by nz-out-0102.google.com with SMTP id 14so545165nzn
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2006 10:09:46 -0700 (PDT)
To: netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
In-Reply-To: <b3f268590608220957g43a16d6bmde8a542f8ad8710b@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Not to mention the name used causes (at least me) some confusion with
BSD's kqueue implementation. Skimming over the patches it actually
looks somewhat like kqueue with the more interesting features removed,
like the ability to pass the filter changes simultaneously with
polling.

Maybe this is a topic that will singe my fur, but what is wrong with
the kqueue API? Will I really have to implement support for yet
another event API in my program.

Rakshasa
