From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] connect() return value.
Date: Tue, 13 Aug 2002 17:47:14 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208131347.RAA21080@sex.inr.ac.ru>
References: <20020813113450.GA19058@anakin.wychk.org>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: glee@gnupilgrims.org (Geoffrey Lee)
In-Reply-To: <20020813113450.GA19058@anakin.wychk.org> from "Geoffrey Lee" at Aug 13, 2 09:34:50 pm
List-Id: netdev.vger.kernel.org

Hello!

> Ah, yes you're right. I was feeling stupid and I forgot to clear the
> errno because re-trying the connect().

Good. :-)

Could you repeat corrected test with repreated nonblocking connect()
on those OSes?

Alexey
