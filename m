From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: 8169 driver with NetGear GA511 card.
Date: Thu, 28 Oct 2004 11:45:10 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410281145.10600.jdmason@us.ibm.com>
References: <41802CA8.8070900@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <41802CA8.8070900@candelatech.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 27 October 2004 06:18 pm, Ben Greear wrote:
> A bit later, my keyboard just stopped working.  The scratch pad
> and USB mouse continued to work.  System wouldn't shut down all
> the way either...forced fsck, system is back online.

I was seeing similar behavior with high workloads and TSO.  Can you confirm 
that you are running with TSO on?  

-- 
Jon Mason
jdmason@us.ibm.com
