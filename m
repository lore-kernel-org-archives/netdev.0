From: Christopher Chan <cchan@outblaze.com>
Subject: dst cache overflow (was network unavailable series)
Date: Wed, 31 Mar 2004 18:28:49 +0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <406A9D61.5020307@outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Increasing net/ipv4/route/gc_thresh seems to have resolved the problem

default: 8192
current: 65535
