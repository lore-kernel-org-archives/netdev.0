From: Chris Wright <chrisw@osdl.org>
Subject: Re: [RFC] SO_PEERSEC - security credentials for Unix stream sockets
Date: Tue, 16 Dec 2003 09:49:04 -0800
Sender: linux-security-module-bounces@wirex.com
Message-ID: <20031216094904.A6791@osdlab.pdx.osdl.net>
References: <20031215173241.B14552@osdlab.pdx.osdl.net>
	<Xine.LNX.4.44.0312160816350.16300-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@osdl.org>,
	Stephen Smalley <sds@epoch.ncsc.mil>, netdev@oss.sgi.com,
	"David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru,
	linux-security-module@wirex.com
Return-path: <linux-security-module-bounces@wirex.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0312160816350.16300-100000@thoron.boston.redhat.com>;
	from jmorris@redhat.com on Tue, Dec 16, 2003 at 08:19:44AM -0500
List-Unsubscribe: <http://mail.wirex.com/mailman/listinfo/linux-security-module>,
	<mailto:linux-security-module-request@mail.wirex.com?subject=unsubscribe>
List-Archive: <http://mail.immunix.com/pipermail/linux-security-module>
List-Post: <mailto:linux-security-module@mail.wirex.com>
List-Help: <mailto:linux-security-module-request@mail.wirex.com?subject=help>
List-Subscribe: <http://mail.wirex.com/mailman/listinfo/linux-security-module>,
	<mailto:linux-security-module-request@mail.wirex.com?subject=subscribe>
Errors-To: linux-security-module-bounces@wirex.com
List-Id: netdev.vger.kernel.org

* James Morris (jmorris@redhat.com) wrote:
> On Mon, 15 Dec 2003, Chris Wright wrote:
> It's not reliable: the required buffer size could change between calls.  
> Do you know of any examples of syscalls which do this?

Of course, just kludgy best guess.  getgroups, getxattr come to mind
right off.

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net
