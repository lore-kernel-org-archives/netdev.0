From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [RFC] netif_rx: receive path optimization
Date: Thu, 31 Mar 2005 16:30:25 -0800
Message-ID: <424C9621.70606@us.ibm.com>
References: <20050330132815.605c17d0@dxpl.pdx.osdl.net>	<20050331120410.7effa94d@dxpl.pdx.osdl.net>	<1112303431.1073.67.camel@jzny.localdomain>	<424C6A98.1070509@hp.com>	<1112305084.1073.94.camel@jzny.localdomain>	<424C7CDC.8050801@hp.com> <424C81B8.6090709@us.ibm.com> <424C8790.6060203@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <424C8790.6060203@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rick Jones wrote:

> Well, I'm in an email discussion with someone who seems to bump their 
> TCP windows quite large, and disable timestamps...

Ah, an oldie but a goodie :), disabling route inheritance
as a result, bumping up their default rto back to 300ms, just
so many things that could go wrong there...

> BTW what is the real world purpose of having the multiple CPU affinity 
> of NIC interrupts?  I have to admit it seems rather alien to me.  (In 
> the context of no onboard NIC smarts being involved that is)

Featuritis Bloatis ;). It's a marketing requirement :).


thanks,
Nivedita
