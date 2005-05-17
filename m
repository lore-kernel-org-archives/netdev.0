From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 12:52:20 -0700
Message-ID: <428A4B74.4050503@us.ibm.com>
References: <Pine.LNX.4.61.0505170914130.29021@linux.site> <428A425F.7000807@hp.com> <428A452B.2010008@us.ibm.com> <200505171531.37167.jheffner@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <200505171531.37167.jheffner@psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

John Heffner wrote:
> On Tuesday 17 May 2005 03:25 pm, Nivedita Singhvi wrote:
> 
>>Yes, a different manifestation of the problem ;). I was talking
>>in the context of current Linux code and the common ethernet drivers
>>and typical current Internet/Intranet latencies.
> 
> 
> The problem is latency independent.

Not entirely - because our reassembly timeout expires, typically.
(If I understand you right).

thanks,
Nivedita
