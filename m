From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: multicast testing
Date: Tue, 06 Jul 2004 18:22:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40EAD1CA.5010105@colorfullife.com>
References: <40EACDB6.10008@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roger Luethi <rl@hellgate.ch>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40EACDB6.10008@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

> Didn't one of you have a multicast test app?

Yes, it's at
http://www.colorfullife.com/~manfred/TestApps/multicast/

In my experience,
- if sending doesn't work then the routing entry is wrong/missing.
- if receiving doesn't work then the hash table setup is broken.

--
    Manfred
