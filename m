From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: Favorite network stress tests?
Date: Wed, 30 Apr 2003 16:52:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030430165244.4b247318.rddunlap@osdl.org>
References: <20030430163542.4e09076f.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030430163542.4e09076f.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 30 Apr 2003 16:35:42 -0700 Stephen Hemminger <shemminger@osdl.org> wrote:

| Does any one have a favorite network stress test?
| There are the usual benchmarks like ttcp, netbench, are there others?
| NFS? 

Here are some places to look/try:

http://www.colorfullife.com/~manfred/net-stress/net-stresstest.txt

ftp://robur.slu.se/pub/Linux/net-development/pktgen-testing/
(is this the same pktgen that is now in 2.5 kernels?)


fsx-linux from Dave Jones:
  http://www.codemonkey.org.uk/cruft/
or from Andrew Morton (used to be here at least):
  http://www.zip.com.au/~akpm/linux/ext3-tools.tar.gz
This is a filesystem test and has been known to find problems, both
locally and over NFS.

--
~Randy
