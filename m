From: Greg Daley <greg.daley@eng.monash.edu.au>
Subject: Re: IP, MAC address duplication detection ?
Date: Mon, 31 Mar 2003 13:00:34 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E87AF52.8060209@eng.monash.edu.au>
References: <003401c2f402$3fbc4450$28acfe81@seong>
Reply-To: greg.daley@eng.monash.edu.au
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Seong Moon <seong@etri.re.kr>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Seong Moon,

the IPv6 implementation does duplicate address detection.
I'm not sure if this is similar to the ipv4 gratuitous ARP.

Greg

Seong Moon wrote:
> Hi, there.
> 
> In Linux box, How can I detect IP/MAC address duplication?
> I'm using kernel-2.4.18 but the kernel does not seem to have
> gratuitous arp implementation. Is it right?
> 
> I know I can detect IP address duplication by arping program
> But I want to implment a following mechanism.
> 
> When the linux machine bootstraps or one of the nework interfaces
> is assigned a MAC/IP address, the linux box can detect the duplication
> of newly assigned MAC/IP address. How can I do this ?
> 
> thanks.
> 
> 
