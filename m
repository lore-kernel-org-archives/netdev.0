From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] connect() return value.
Date: Tue, 13 Aug 2002 19:28:41 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208131528.TAA21381@sex.inr.ac.ru>
References: <20020813143246.GA20943@anakin.wychk.org>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: glee@gnupilgrims.org (Geoffrey Lee)
In-Reply-To: <20020813143246.GA20943@anakin.wychk.org> from "Geoffrey Lee" at Aug 14, 2 00:32:46 am
List-Id: netdev.vger.kernel.org

Hello!

> First off,
et al.

Great, I think we will change this too.

Could you repeat that test with read() after incomplete connect?
That your test was apparently invalid because of the same errno mistake,
so results may be different. Only, please, use read() with non-zero length.

Alexey
