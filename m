From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Mon, 02 Jul 2007 18:44:52 -0700
Message-ID: <4689AA14.5020805@intel.com>
References: <08FE5CC30C9A3F41BF819A502CF7BF6E019416BA@fmsmsx411.amr.corp.intel.com>
	<46899408.4030407@hp.com> <20070703005537.GB3962@falooley.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	"Kok,  Auke-jan H" <auke-jan.h.kok@intel.com>,
	Rick Jones <rick.jones2@hp.com>, Jeff Garzik <jeff@garzik.org>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jason Lunz <lunz@reflexsecurity.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-reply-to: <20070703005537.GB3962@falooley.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Jason Lunz wrote:
> On Mon, Jul 02, 2007 at 05:10:48PM -0700, Rick Jones wrote:
>> Rambling a bit, and recognizing that "e1000new" was probably just a 
>> strawman name, but I suspect that a _very_ different name for the new 
>> driver would be a good thing, rather than a varition on the e1000 theme. 
> 
> I rather liked the "e1000e" name suggested by Christoph Hellwig. That
> may not be different enough for you, though. Anything but "e1000new";
> it won't be new forever.

hehe, yes, true. And the e1000new was just a placeholder. e1000e seems much more 
attractive for me, especially if we end up splitting the driver at the pci/pci-e 
boundary (like ixgb and ixgbe are).

Auke



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
