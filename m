From: Kristen Carlson <kristenc@cs.pdx.edu>
Subject: patricia tries vs. hash for routing?
Date: Thu, 18 Sep 2003 10:29:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030918172910.GA22091@sirius.cs.pdx.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
I'm wondering if somebody has already written a patch that replaces the
current routing algorithm (hash) with one that is based on a trie based
algorithm?  I'm also wondering if anybody has done any performance 
comparisons with very large route tables to see which one scales better?
thanks,
Kristen
 
-- 
WWXD (What Would Xena Do?) 
