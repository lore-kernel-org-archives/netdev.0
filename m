From: Patrick McHardy <kaber@trash.net>
Subject: Re: patch: namsiz
Date: Sun, 16 Jan 2005 19:49:51 +0100
Message-ID: <41EAB74F.6060507@trash.net>
References: <1105900522.1090.798.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@znyx.com
In-Reply-To: <1105900522.1090.798.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal Hadi Salim wrote:

>heres one ive wanted to do for a while - dissociate action name size
>from ifnamsiz. for now set it to namize, but later may change it.
>
The same can be done for sch_api and cls_api. I'll add it to my tree
when I'm done with the current fixes, unfortunately one of them has
to touch basically all files in net/sched and I want to avoid clashes.

Regards
Patrick
