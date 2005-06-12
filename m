From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [PATCH] fix small DoS on connect() (was Re: BUG: Unusual TCP Connect() results.)
Date: Sun, 12 Jun 2005 20:10:33 +0300
Message-ID: <200506122010.33075.vda@ilport.com.ua>
References: <42A9C607.4030209@unixtrix.com> <20050611062413.GA1324@pcw.home.local> <20050611074350.GD28759@alpha.home.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: xschmi00@stud.feec.vutbr.cz, alastair@unixtrix.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Willy Tarreau <willy@w.ods.org>, "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050611074350.GD28759@alpha.home.local>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Does it seem appropriate for mainline ? In this case, I would also backport
> it to 2.4 and send it to you for inclusion.

It does not contain a comment why it is configurable.
--
vda
