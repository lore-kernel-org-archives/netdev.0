From: James Morris <jmorris@redhat.com>
Subject: Re: Asynchronous crypto layer.
Date: Sun, 31 Oct 2004 11:09:20 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0410311107160.677-100000@thoron.boston.redhat.com>
References: <10313.1099236970@marajade.sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Michal Ludvig <mludvig@suse.cz>, <johnpol@2ka.mipt.ru>, <hadi@cyberus.ca>,
        <netdev@oss.sgi.com>, <cryptoapi@lists.logix.cz>,
        Eugene Surovegin <ebs@ebshome.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
In-Reply-To: <10313.1099236970@marajade.sandelman.ottawa.on.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 31 Oct 2004, Michael Richardson wrote:

>   There are lots of situations where, yes, a 2Ghz CPU can do IPsec much
> faster and with lower latency and with less jitter than hardware.
> 
>   However, the CPU might have other important things to do. Things that
> make the owner money. 

I guess control over this should be tunable, perhaps just a boolean of 
whether to try and aim for raw speed or for reduced CPU contention.


- James
-- 
James Morris
<jmorris@redhat.com>
