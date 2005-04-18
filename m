From: Masoud Sharbiani <masouds@masoud.ir>
Subject: Re: Does a forwarded packet has a local socket with it?
Date: Mon, 18 Apr 2005 14:06:15 -0400
Message-ID: <1113847575.19942.1.camel@localhost.localdomain>
References: <20050418140348.33642.qmail@web51509.mail.yahoo.com>
Reply-To: masouds@masoud.ir
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Park Lee <parklee_sel@yahoo.com>
In-Reply-To: <20050418140348.33642.qmail@web51509.mail.yahoo.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2005-04-18 at 07:03 -0700, Park Lee wrote:
> On Mon, 18 Apr 2005 at 08:03, jamal wrote:
> > simple answer: no
> 
> Thank you very much.
> 
> Still, Does a forwarded packet also have no any kernel
> socket with it?  i.e. Is a forwarded packet not
> associated with any socket at all? 
> 
No.

> When the forwarded packet arrived at its destination
> machine, is there any socket associated with the
> packet on the destination machine?
It better be :-) 
Otherwise, it could be ignored or just refused (as in connection
refused).
> 
> Thanks again. 
> 
> Best Regards,
> Park Lee
> 
> 
> 		

cheers, 
Masoud
-- 
Masoud Sharbiani <masouds at masoud.ir>

