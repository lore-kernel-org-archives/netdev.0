From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Update FarSync WAN driver in 2.6
Date: Sun, 29 Feb 2004 13:53:19 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4042351F.9070703@pobox.com>
References: <7C078C66B7752B438B88E11E5E20E72E25CBF0@general.hq.farsitecommunications.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kevin Curtis <kevin.curtis@farsite.co.uk>
In-Reply-To: <7C078C66B7752B438B88E11E5E20E72E25CBF0@general.hq.farsitecommunications.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hum...  Patch looks OK to appy, but does not apply against the latest 
2.6.x kernel.

Also, it is possible to split your patch into two pieces:  one patch 
with nothing but indentation/whitespace cleanups, and the other patch 
with functional changes?

	Jeff
