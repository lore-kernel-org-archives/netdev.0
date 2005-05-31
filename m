From: "David S. Miller" <davem@davemloft.net>
Subject: Re: PATCH: rtnetlink explicit flags setting
Date: Tue, 31 May 2005 14:43:38 -0700 (PDT)
Message-ID: <20050531.144338.112623594.davem@davemloft.net>
References: <1117197157.6688.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1117197157.6688.24.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Fri, 27 May 2005 08:32:37 -0400

> This patch rectifies some rtnetlink message builders that derive the
> flags from the pid. It is now explicit like the other cases
> which get it right.
> 
> Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

Please use explicit "unsigned int flags" instead of "unsigned flags".
