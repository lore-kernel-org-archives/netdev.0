From: "John W. Linville" <linville@redhat.com>
Subject: Re: [PATCH 2.6.12-rc2 0/17] bonding: sysfs interface...
Date: Fri, 8 Apr 2005 12:53:19 -0400
Message-ID: <20050408165319.GF32431@redhat.com>
References: <Pine.LNX.4.61.0504081530560.10355@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Radheka Godse <radheka.godse@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0504081530560.10355@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 08, 2005 at 04:15:24PM -0700, Radheka Godse wrote:
> 
> This patch set implements the sysfs interface for bonding and has a couple 
> bug fixes. We have done a full test pass and consider these patches ready 
> for inclusion upstream. We have submitted them to bonding-devel several 
> times and have incorporated feedback and fixes all known issues.

I, for one, view these patches as very welcome.  I intend to comment
further later, but for now...

FC3 users are invited to use the test kernels here:

	http://people.redhat.com/linville/kernels/fc3/

I have incorporated the bonding driver from 2.6.12-rc2 plus the bonding
sysfs patches (along with some unrelated patches) to the current FC3
kernel sources.  If you are an FC3 user and you want to experiment w/
these changes, this is the easiest way for you to do so.

I'd love to hear feedback, either on the lists or directly to this
address.

Thanks,

John
-- 
John W. Linville
linville@redhat.com
