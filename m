From: "Alan Shih" <alan@storlinksemi.com>
Subject: RE: Force client to receive MSS > PMTU ?
Date: Tue, 17 Feb 2004 12:26:04 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <002501c3f594$443a6b30$7100a8c0@VALUED51C59791>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
In-Reply-To: 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


-----Original Message-----
From: Alan Shih [mailto:alan@storlinksemi.com] 
Sent: Tuesday, February 17, 2004 11:40 AM
To: 'netdev@oss.sgi.com'
Subject: Force client to receive MSS > PMTU ?

Hi all,

I am experimenting with ip fragmentation.  I would like to force a
generic client [unmodified Linux] to accept MSS that is larger than PMTU
[like 4K]. Is that possible? Right now the negotiation always forces
down to 1460.

Thanks

Al
