From: Jon D Mason <jonmason@us.ibm.com>
Subject: Re: Bad UDP checksum with 82540EM
Date: Sat, 7 Feb 2004 15:37:16 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFE5352D34.67E10D98-ON87256E33.00725857-86256E33.0076C481@us.ibm.com>
References: <je65ejvwpa.fsf@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: cramerj@intel.com, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <je65ejvwpa.fsf@sykes.suse.de>
To: Andreas Schwab <schwab@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This probably isn't helpful, but it sounds like a hardware error.  Is the 
error occurring on multiple/all HP adapters, or only one? 

Also, your driver code is old, the latest is 5.2.30.1 (goto 
http://sourceforge.net/projects/e1000/).  I don't think that has anything 
to do with it though.

Jon Mason                jonmason@us.ibm.com
Software Engineer        Phone:(512)838.4162
Linux eServer I/O        Fax:  (512)838.3509
