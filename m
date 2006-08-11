From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 0/4]:  powerpc/cell spidernet ethernet driver fixes
Date: Fri, 11 Aug 2006 22:27:22 +0200
Message-ID: <200608112227.24140.arnd@arndb.de>
References: <20060811170337.GH10638@austin.ibm.com> <20060811174439.GA30191@mars.ravnborg.org> <20060811193102.GN10638@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Sam Ravnborg <sam@ravnborg.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	James K Lewis <jklewis@us.ibm.com>,
	Utz Bacher <utz.bacher@de.ibm.com>,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964775AbWHKU2M@vger.kernel.org>
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20060811193102.GN10638@austin.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 11 August 2006 21:31, Linas Vepstas wrote:
> I put my name at the top when I was the primary author. 
> I put Jim's name at the top when he was the primary author. 
> 
> Both names are there because I sat in Jim's office and used
> his keyboard. I got him to compile and run the tests on
> his hardware, and we'd then debate the results.

When the patch gets added to a git repository, they end up
having your name on it, because the author is determined
from the person who sent the patch.

For the patches where Jim is the main author, you should put a 

From: James K Lewis <jklewis@us.ibm.com>

into the first line of the email body. That will make the
scripts do the right thing. The order of the Signed-off-by:
lines is used is independant from authorship and should
list the name of the submitter last.

	Arnd <><
