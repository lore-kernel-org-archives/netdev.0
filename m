From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [ANNOUNCE] IPTV-Analyzer project released v0.9.2
Date: Thu, 02 Jun 2011 14:37:14 -0400
Message-ID: <1307039834.2703.178.camel__13663.6585965336$1307039894$gmane$org@probook>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: hawk <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:48333 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784Ab1FBShp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 14:37:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new release 0.9.2 of the IPTV-Analyzer project is coming to you
from Montreal, Canada.

 The new feature is SNMP traps, for no_signal detection.

The collector sends SNMP "no_signal" traps, when the state
transition from, signal to no-signal, and back from no-signal to
signal.  The SNMP traps are described via an compliant MIB.

 Homepage:
  http://www.iptv-analyzer.org

 Git tree:
  https://github.com/netoptimizer/IPTV-Analyzer

The IPTV-Analyzer is a continuous/real-time tool for analyzing the
contents of MPEG2 Transport Stream (TS) packets, which is commonly
used for IPTV multicast signals. The main purpose is continuous
quality measurement, with a focus on detecting MPEG2 TS/CC packet
drops.

 Bugreports and feature requests please use:
  https://github.com/netoptimizer/IPTV-Analyzer/issues

-- 
Best regards,
  Jesper Dangaard Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

