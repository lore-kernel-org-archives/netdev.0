From: Jason Lunz <lunz@reflexsecurity.com>
Subject: Re: [Fwd: [E1000] NAPI re-insertion w/ changes]
Date: Tue, 1 Apr 2003 19:23:10 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <slrnb8jppb.eh6.lunz@stoli.localnet>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010107D314@orsmsx402.jf.intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

scott.feldman@intel.com said:
>>  I've tested the patch that removes some of the PCI-accesses.  I
>>  think I sent  you some version of it. Anyway it seems to have some
>>  effects. If Jason has time we will get some numbers from his
>>  instrument/setup.
> 
> Ok, let's see.

It works. Reducing PCI accessess gives a measurable improvement. I'll
post plots later today.

-- 
Jason Lunz			Reflex Security
lunz@reflexsecurity.com		http://www.reflexsecurity.com/
