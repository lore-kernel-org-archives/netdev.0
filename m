From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Bonding-devel] Re: [bonding] compatibilty issues
Date: Wed, 1 Oct 2003 00:05:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031001000524.7e0d851e.davem@redhat.com>
References: <shmulik.hen@intel.com>
	<200309301442.31991.shmulik.hen@intel.com>
	<200309301639.h8UGdqCq026858@death.ibm.com>
	<20030930213650.GA71877@calma.pair.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, shmulik.hen@intel.com, jgarzik@pobox.com,
        chad@tindel.net, bonding-devel@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Chad N. Tindel" <chad@tindel.net>
In-Reply-To: <20030930213650.GA71877@calma.pair.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 30 Sep 2003 17:36:50 -0400
"Chad N. Tindel" <chad@tindel.net> wrote:

> My recommendations are more towards the middle than either end.  I would
> like to see us get rid of the _OLD ioctls in the 2.6 kernel specifically 
> because it uses the SIOCDEVPRIVATE ioctls.
 ...
> I would like to see them stay in 2.4 for the rest of the 2.4 tree
> specifically so that people who want to run on 3 year old systems
> can continue to do so without us breaking their world.

I think this is fine, personally.

I defer to Jeff for final judgment, he should be allowed to chime in
at least once more.
